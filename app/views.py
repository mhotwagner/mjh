from django.http import HttpResponse
from django.shortcuts import render
from django.views.generic import TemplateView, View

from .renderers import renderers
from .renderers.renderers import BashRenderer


# Create your views here.


class IndexView(TemplateView):
    template_name = 'index.html'

    def get(self, request, *args, **kwargs):
        # import ipdb; ipdb.set_trace()
        return super().get(request, *args, **kwargs)


class PolyglotView(View):
    def get(self, request, language, *args, **kwargs):
        print(language)
        print(args)
        print(kwargs)

        # import ipdb; ipdb.set_trace()
        # return HttpResponse('OK')
        # try:
        #     renderer = renderers

        renderer = BashRenderer(request)
        print(renderer)
        data = renderer.render()
        return HttpResponse(data)
