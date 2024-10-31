import gspread
from oauth2client.service_account import ServiceAccountCredentials
import os


sheet_id = '1v7xBELkY1Dy3PsD6yBnQEws0l5gA9z0mCMwJ5gI3oMM'

class ChangeGsheet:
    def authenticate_google_sheets(self):
        scope = [
            'https://spreadsheets.google.com/feeds',
            'https://www.googleapis.com/auth/drive'
        ]

        credentials = {
            'type': os.getenv('TYPE'),
            'project_id': os.getenv('PROJECT_ID'),
            'private_key_id': os.getenv('PRIVATE_KEY_ID'),
            'private_key': os.getenv('PRIVATE_KEY').replace('\\n', '\n'),
            'client_email': os.getenv('CLIENT_EMAIL'),
            'client_id': os.getenv('CLIENT_ID'),
            'auth_uri': os.getenv('AUTH_URI'),
            'token_uri': os.getenv('TOKEN_URI'),
            'auth_provider_x509_cert_url': os.getenv('AUTH_PROVIDER_X509_CERT_URL'),
            'client_x509_cert_url': os.getenv('CLIENT_X509_CERT_URL'),
        }

        credentials = ServiceAccountCredentials.from_json_keyfile_dict(
            credentials, scope)
        client = gspread.authorize(credentials)
        return client
    
    def __init__(self, sheetid):
        self.client = self.authenticate_google_sheets()
        self.spreadsheet = self.client.open_by_key(sheetid)
        self.sheet = self.spreadsheet.sheet1

    def insert_row(self, row_data, row_key):
        # Get all rows from the sheet
        rows = self.sheet.get_all_values()

        # Check if any row starts with the same row_key
        for row in rows:
            if row[:len(row_key)] == row_key:
                return  # Exit the function as the row key already exists

        # If no row with the same row_key exists, append the new row
        self.sheet.append_row(row_data)
        print("Row inserted successfully.")

    def update_row(self, row_key, updated_data):
        rows = self.sheet.get_all_values()
        for idx, row in enumerate(rows):
            if row[:len(row_key)] == row_key:
                for col_idx, value in enumerate(updated_data):
                    self.sheet.update_cell(idx + 1, col_idx + 1, str(value))
                break

    def delete_row(self, row_key):
        rows = self.sheet.get_all_values()
        for idx, row in enumerate(rows):
            if row[:len(row_key)] == row_key:
                self.sheet.delete_rows(idx+1)
                break
