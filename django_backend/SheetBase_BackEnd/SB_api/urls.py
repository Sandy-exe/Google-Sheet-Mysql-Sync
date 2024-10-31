from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import AnimeViewSet
from . import views

router = DefaultRouter()
router.register(r'anime', AnimeViewSet)  # Change to your preferred endpoint

urlpatterns = [
    path('', include(router.urls)),
]
