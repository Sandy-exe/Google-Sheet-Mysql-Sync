from django.db import models
from django.utils import timezone


class Anime(models.Model):
    id = models.CharField(max_length=50, primary_key=True)
    anime_name = models.CharField(max_length=200)
    season = models.PositiveIntegerField()
    episode_number = models.PositiveIntegerField()
    release_time = models.TimeField()
    release_date = models.DateField()
    release_day = models.CharField(max_length=10)
    updated_datetime = models.DateTimeField(
        auto_now=True)  # Automatically updates on save
    created_datetime = models.DateTimeField(
        auto_now_add=True)  # Set only once on creation

    def __str__(self):
        return f"{self.anime_name} - Season {self.season}, Episode {self.episode_number}"


class SbApiAnimeAuditLog(models.Model):
    anime_id = models.CharField(max_length=50)  # Matches `id` in `Anime`
    # Matches `anime_name` in `Anime`
    anime_name = models.CharField(max_length=200)
    season = models.PositiveIntegerField()  # Matches `season` in `Anime`
    # Matches `episode_number` in `Anime`
    episode_number = models.PositiveIntegerField()
    release_time = models.TimeField()  # Matches `release_time` in `Anime`
    release_date = models.DateField()  # Matches `release_date` in `Anime`
    # Matches `release_day` in `Anime`
    release_day = models.CharField(max_length=10)
    updated_datetime = models.DateTimeField()  # Stores updated time from `Anime`
    created_datetime = models.DateTimeField()  # Stores created time from `Anime`

    # Logs the type of operation ('INSERT', 'UPDATE', 'DELETE')
    function_type = models.CharField(max_length=10)

    # Whether the log entry was processed
    processed = models.BooleanField(default=False)

    class Meta:
        db_table = 'sb_api_anime_audit_log'
