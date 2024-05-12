from django.urls import path

from .views import IndexView, PolyglotView

urlpatterns = [
    path('', IndexView.as_view(), name='index'),
    path('polyglot/<str:language>/', PolyglotView.as_view(), name='polyglot'),
    path('polyglot/<str:language>/<path:remainder>/', PolyglotView.as_view(), name='polyglot'),
]
