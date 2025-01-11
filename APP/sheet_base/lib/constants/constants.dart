
//These constants are used in Services/api_services.dart to perform CRUD functions in both Mysql and GSheets
const String baseUrl = "http://192.168.0.104:8000/api/anime/";

// Your Google Sheets API credentials
const credentials = r'''
{
  "type": "service_account",
  "project_id": "sheetbase-436908",
  "private_key_id": "8d318c6de1e9d4207ecd9e4902bfd0efcabf2bc4",
  "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDFQ9WXhk+1nCjo\nx++/we4jITjpI9pdme3sDUar80KJI3b3+Vi321MtWsistbEkZ89WiG1nZpeJxUA9\nkjWOWNTWt/oJ+2QouoJOBjZXErds9cGBZS5oke8ysuXKqQuco1NJ47Yc0S4xHUM3\nI8CKsJN8MXuOTOOOJpDtcEEgbD5K6SbpkpnLyq3xSRYYnxZOJ53MLc+amL4Uq9WF\nKODCWYBGEL9qOmCe9HEaVS+3XISxUd6v0gIoO/t5jkruGmptxmtLS/kB4Tk5HtR8\nf3MalHzz8KfuBv18U+T0JR/YsY+C/QEs4PMe7VKpBQ00y5D3FHlZGbfGKdqCIOGw\nS+FUjqn3AgMBAAECggEACONyl15E7zD3Iu4HXoOVgF25279y0m7iKpW6jnrqj5Va\ngffpSHeIeu2xRx70uWg4DnUdQOB9iYaqy1twMFbOWFJ34MVEERW+U1eyUSAVxcIZ\nEwSFH88bkRRAiG4viMJPOXAaP5gpVas04SIqRdWI/7qXD6VlR31zYE+Dj7tw3x0o\nFELPhhyT2RCNpDYG0D/NsjSX/eOAKRmkXlIHAxhwO4owWIzAvCYfuQ3TAJ08b/uX\nB7hy4AxqWibCDdMhTlHJD+dTXBi2sEk4OpVXh56gBM502bbJgAeWu3OWC58iVD9r\nyq2J5Y+mkMmx36V7PJiMisjSv+NtA7/a5hUuCLqNIQKBgQDhpRYs7Dhg9powsSFz\nzhO6z3RvAJ05z/QyizCmvKC/OA7FMpxdTbTMhFgVJ+y2ln43XQ8mM7Doc+U4+qm1\ni+pHxAmyekYp+wjqK5k//BlzjDNOhnjopk3nb5GIHv6qKeu/Bb0wUwjJFQ7WlpAb\nFo4xVvwN+VkT0+1h+9lFj9iyJwKBgQDfzWGoAPBdTumcmpSxTPaAw9RSQW2DAK5+\nTycvQw9qzG6yzl19YzS7HDn0z728fMkpri3fHqZvIEPiIiapI9MAysIJM8TG2ush\nup0FsjCDbfCzSfAcZOIe4/8MDCB6bJg70Npevu2hCIoNPJY8kThrnAxdiVq17w7F\nq5ktEj+7sQKBgQCtBLT4RTkFwJGCfI+2CHJAcApLgyELz1Tj3K61azWm6gkJVEFp\nmcfkeiZAMpjjeInXUdfn5wLjetps0meG+X3vAXaeD/v0/LRdOokL8vZhD0PYFmxn\nl/1sVLQ2t+119Sb7Fh93CnRWG3uBN3nQC3+EfbpPzL5s4bfHxiFXoXD7SQKBgD27\nK+2oXKSQKLXumYcSQIgh/AW4UFmrLXZfpOJPcAg4XWxqqbT1UU0vKvlQ9/fuv5oE\nlliN3sCWOMM+QkWzQPdd9gmNwwBK0EKcc8VnciQ+hf8eLOHYHdsBbo9HJQo/u/n7\n0NADgA5ECbg+9v273MEp6OtAAMpgJ0X04CpjdzrxAoGAJH652ZjPZbOyK6IHW2K0\n6RkztV0FY/cjz5MUhpyB74drxfP8Ns6vD6O8+YQN2IqMq7HV/wgNTF8xPKZ0TbG6\nsu42RjPTuUzS2KI9Vian+EIZchFaHphk42G6JL7uHQpQDpdfERjZby6Ct/oqEErb\nt/BQLlEmw0qQ/NmF6gtGFnc=\n-----END PRIVATE KEY-----\n",
  "client_email": "service-account@sheetbase-436908.iam.gserviceaccount.com",
  "client_id": "105871680440677979954",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/service-account%40sheetbase-436908.iam.gserviceaccount.com"
}
''';

// SpreadSheet ID i created using GOOGLEAPI
const spreadsheetId = '1v7xBELkY1Dy3PsD6yBnQEws0l5gA9z0mCMwJ5gI3oMM';
