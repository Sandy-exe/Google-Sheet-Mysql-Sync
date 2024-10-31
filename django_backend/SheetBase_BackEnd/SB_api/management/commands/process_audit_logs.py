from django.core.management.base import BaseCommand
from SB_api.models import SbApiAnimeAuditLog  # Keep this import for audit log
# Adjust the import path according to your project structure
from SB_api.gsheet import ChangeGsheet


class Command(BaseCommand):
    help = 'Process audit log and perform CUD operations on Google Sheets'

    def handle(self, *args, **kwargs):
        # Initialize the Google Sheets handler with your sheet ID
        # Replace 'your_sheet_id' with your actual sheet ID
        gsheet = ChangeGsheet(sheetid='your_sheet_id')

        # Fetch unprocessed audit logs
        audit_logs = SbApiAnimeAuditLog.objects.filter(processed=False)

        for log in audit_logs:
            try:
                # Assuming the anime ID is your unique key for rows
                row_key = [log.anime_id]

                if log.function_type == 'INSERT':
                    # Prepare the data to insert as a row
                    row_data = [
                        log.anime_id,
                        log.anime_name,
                        log.season,
                        log.episode_number,
                        log.release_time.isoformat(),  # Convert time to string if needed
                        log.release_date.isoformat(),   # Convert date to string if needed
                        log.release_day,
                    ]
                    gsheet.insert_row(row_data, row_key)

                elif log.function_type == 'UPDATE':
                    updated_data = [
                        log.anime_name,
                        log.season,
                        log.episode_number,
                        log.release_time.isoformat(),
                        log.release_date.isoformat(),
                        log.release_day,
                    ]
                    gsheet.update_row(row_key, updated_data)

                elif log.function_type == 'DELETE':
                    gsheet.delete_row(row_key)

                # Mark the log as processed
                log.processed = True
                log.save()

            except Exception as e:
                self.stdout.write(self.style.ERROR(
                    f'Error processing log {log.id}: {str(e)}'))

        self.stdout.write(self.style.SUCCESS(
            'Successfully processed all audit logs.'))
