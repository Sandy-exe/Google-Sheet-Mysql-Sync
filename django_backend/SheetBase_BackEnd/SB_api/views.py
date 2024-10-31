from datetime import datetime, timezone
import json
import os
import time
from dotenv import load_dotenv
import logging
from .models import Anime
from .serializers import AnimeSerializer

from rest_framework import viewsets
from rest_framework.response import Response
from rest_framework import status

from django.views.decorators.csrf import csrf_exempt
from django.db import connection
from django.shortcuts import render
from django.http import JsonResponse

from django.conf import settings
import gspread
from SB_api.gsheet import ChangeGsheet


sheet_id = '1v7xBELkY1Dy3PsD6yBnQEws0l5gA9z0mCMwJ5gI3oMM'

class AnimeViewSet(viewsets.ModelViewSet):
    queryset = Anime.objects.all()
    serializer_class = AnimeSerializer

    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.gsheet_manager = ChangeGsheet(sheetid=sheet_id)

    def create(self, request, *args, **kwargs):
        print(f'POST request received with data: {request.data}')
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            anime_instance = serializer.save(
                created_datetime=datetime.now(), updated_datetime=datetime.now())
            print(f'Created object: {serializer.data}')

            row_key = [str(anime_instance.id)]
            
            formatted_row = [
                anime_instance.id,
                anime_instance.anime_name,
                str(anime_instance.season),
                str(anime_instance.episode_number),
                str(format_time(anime_instance.release_time)),
                str(format_date(anime_instance.release_date)),
                anime_instance.release_day,
                anime_instance.updated_datetime.isoformat(),  # Convert to string
                anime_instance.created_datetime.isoformat()   # Convert to string
            ]

            # Debug: Print formatted_row to identify potential serialization issues
            print(f'Formatted row for Google Sheets: {formatted_row}')

            # Ensure that the formatted_row only contains serializable types
            self.gsheet_manager.insert_row(formatted_row,row_key)
            return Response(serializer.data, status=status.HTTP_201_CREATED)

        print(f'POST request errors: {serializer.errors}')
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def update(self, request, *args, **kwargs):
        print(f'PUT request received with data: {request.data}')
        partial = kwargs.pop('partial', False)
        instance = self.get_object()
        serializer = self.get_serializer(
            instance, data=request.data, partial=partial)

        if serializer.is_valid():
            anime_instance = serializer.save(updated_datetime=datetime.now())
            print(f'Updated object: {serializer.data}')

            row_key = [str(instance.id)]
            formatted_row = [
                anime_instance.id,
                anime_instance.anime_name,
                str(anime_instance.season),
                str(anime_instance.episode_number),
                str(format_time(anime_instance.release_time)),
                str(format_date(anime_instance.release_date)),
                anime_instance.release_day,
                anime_instance.updated_datetime.isoformat(),  # Convert to string
                anime_instance.created_datetime.isoformat()   # Convert to string
            ]
            self.gsheet_manager.update_row(row_key, formatted_row)
            return Response(serializer.data)

        print(f'PUT request errors: {serializer.errors}')
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        print(f'DELETE request received for object: {instance}')

        row_key = [str(instance.id)]
        self.gsheet_manager.delete_row(row_key)
        self.perform_destroy(instance)
        print(f'Object deleted.')
        return Response(status=status.HTTP_204_NO_CONTENT)


# Load environment variables from .env file
load_dotenv()

logger = logging.getLogger(__name__)

def format_time(value):
    return value.strftime('%H:%M:%S')


def format_date(value):
    return value.strftime('%Y-%m-%d')

# View to handle form submission and sync
@csrf_exempt
def sync_sheet_and_db(request):
    if request.method == 'POST':
        client = ChangeGsheet(sheetid=sheet_id).authenticate_google_sheets()
        spreadsheet = client.open_by_key(sheet_id)
        sheet = spreadsheet.sheet1
        sheet_data = sheet.get_all_records()

        db_data = Anime.objects.all()
        sheet_dict = {str(record['id']): record for record in sheet_data}
        db_dict = {str(anime.id): anime for anime in db_data}

        missing_in_db = set(sheet_dict.keys()) - set(db_dict.keys())
        missing_in_sheet = set(db_dict.keys()) - set(sheet_dict.keys())

        print(missing_in_db)
        print(missing_in_sheet)

        for record_id in missing_in_db:
            record = sheet_dict[record_id]
            Anime.objects.create(
                id=record['id'],
                anime_name=record['anime_name'],
                season=record['season'],
                episode_number=record['episode_number'],
                release_time=record['release_time'],
                release_date=record['release_date'],
                release_day=record['release_day'],
                created_datetime=datetime.now(),
                updated_datetime=datetime.now()
            )

        for record_id in missing_in_sheet:
            anime_instance = db_dict[record_id]
            formatted_row = [
                anime_instance.id,
                anime_instance.anime_name,
                str(anime_instance.season),
                str(anime_instance.episode_number),
                str(format_time(anime_instance.release_time)),
                str(format_date(anime_instance.release_date)),
                anime_instance.release_day,
                anime_instance.updated_datetime.isoformat(),  # Convert to string
                anime_instance.created_datetime.isoformat()   # Convert to string
            ]
            sheet.append_row(formatted_row)

        print(sheet_dict)

        for record_id in sheet_dict.keys():
            
            if record_id in db_dict:
                sheet_record = sheet_dict[record_id]
                anime_instance = db_dict[record_id]

                sheet_updated_datetime = datetime.fromisoformat(
                    sheet_record['updated_datetime'])

                sheet_updated_timestamp = sheet_updated_datetime.timestamp(
                )
                anime_instance_updated_timestamp = anime_instance.updated_datetime.timestamp()

                if sheet_updated_timestamp > anime_instance_updated_timestamp:
                    anime_instance.anime_name = sheet_record['anime_name']
                    anime_instance.season = sheet_record['season']
                    anime_instance.episode_number = sheet_record['episode_number']
                    anime_instance.release_time = sheet_record['release_time']
                    anime_instance.release_date = sheet_record['release_date']
                    anime_instance.release_day = sheet_record['release_day']
                    anime_instance.updated_datetime = sheet_record['updated_datetime']
                    anime_instance.save()
                else:
                    formatted_row = [
                        anime_instance.id,
                        anime_instance.anime_name,
                        str(anime_instance.season),
                        str(anime_instance.episode_number),
                        str(format_time(anime_instance.release_time)),
                        str(format_date(anime_instance.release_date)),
                        anime_instance.release_day,
                        anime_instance.updated_datetime.isoformat(),  # Convert to string
                        anime_instance.created_datetime.isoformat()   # Convert to string
                    ]
                    try:
                        row_index = find_row_index(sheet, anime_instance.id)
                        print(row_index)
                        for col_idx, value in enumerate(formatted_row):
                            sheet.update_cell(row_index, col_idx + 1, str(value))
                    except Exception as e :
                        print(e)
                        

        response_data = {
            'missing_in_db': len(missing_in_db),
            'missing_in_sheet': len(missing_in_sheet),
            'status': 'Sync complete',
        }
        return JsonResponse(response_data)

    return JsonResponse({'error': 'Invalid request method'}, status=400)



def find_row_index(sheet, record_id):
    """Helper function to find the row index in the Google Sheet by record ID."""
    records = sheet.get_all_records()
    # Start at 2 to account for header
    for index, record in enumerate(records, start=2):
        if record['id'] == record_id:
            return index
    return None


@csrf_exempt
def google_sheet_data(request):
    if request.method == 'POST':
        try:
            data = json.loads(request.body)
            action = data.get('action')
            row_data = data.get('rowData')

            print(data,action,row_data)

            if action == 'update':
                anime_id = row_data[0]
                anime_instance = Anime.objects.get(id=anime_id)
                anime_instance.anime_name = row_data[1]
                anime_instance.season = row_data[2]
                anime_instance.episode_number = row_data[3]
                anime_instance.release_time = row_data[4]
                anime_instance.release_date = row_data[5]
                anime_instance.release_day = row_data[6]
                anime_instance.updated_datetime = datetime.now()  # Update the timestamp
                anime_instance.save()
                return JsonResponse({'status': 'success', 'message': 'Anime updated successfully'}, status=200)

            elif action == 'create':
                if any(row_data):
                    anime_instance = Anime(
                        id=row_data[0],
                        anime_name=row_data[1],
                        season=row_data[2],
                        episode_number=row_data[3],
                        release_time=row_data[4],
                        release_date=row_data[5],
                        release_day=row_data[6],
                        created_datetime=datetime.now(),  # Set created timestamp
                        updated_datetime=datetime.now()   # Set updated timestamp
                    )
                    anime_instance.save()
                    return JsonResponse({'status': 'success', 'message': 'Anime created successfully'}, status=201)
                else:
                    return delete_non_existing_anime()

            return JsonResponse({'status': 'error', 'message': 'Invalid action'}, status=400)

        except json.JSONDecodeError:
            return JsonResponse({'status': 'error', 'message': 'Invalid JSON'}, status=400)
        except Anime.DoesNotExist:
            return JsonResponse({'status': 'error', 'message': 'Anime not found'}, status=404)
        except Exception as e:
            return JsonResponse({'status': 'error', 'message': str(e)}, status=500)

    else:
        return JsonResponse({'status': 'error', 'message': 'Only POST requests are allowed.'}, status=405)


def delete_non_existing_anime():
    client = ChangeGsheet(sheet_id=sheet_id).authenticate_google_sheets()
    spreadsheet = client.open_by_key(sheet_id)
    sheet = spreadsheet.sheet1
    sheet_data = sheet.get_all_records()

    db_data = Anime.objects.values(
        'id', 'anime_name', 'season', 'episode_number', 'release_time', 'release_date', 'release_day')

    sheet_set = {str(record['id']) for record in sheet_data}
    db_set = {str(record['id']) for record in db_data}

    ids_to_delete = db_set - sheet_set

    for anime_id in ids_to_delete:
        Anime.objects.filter(id=anime_id).delete()

    return JsonResponse({'status': 'success', 'message': 'Non-existing anime records deleted successfully'}, status=200)
