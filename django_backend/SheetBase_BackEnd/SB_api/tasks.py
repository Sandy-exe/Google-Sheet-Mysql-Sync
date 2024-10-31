from celery import shared_task
from django.core.management import call_command


@shared_task
def process_audit_logs():
    call_command('process_audit_logs')  # Replace with your actual command name
