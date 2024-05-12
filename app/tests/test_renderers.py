from unittest.mock import Mock

from django.test import TestCase

from app.renderers.renderers import BaseRenderer


class BaseRendererTestCase(TestCase):
    def setUp(self):
        self.request_mock = Mock()
        # self.renderer = BaseRenderer(request_mock)

    def test_render(self):
        renderer = BaseRenderer(self.request_mock)
        with self.assertRaises(NotImplementedError):
            renderer.render()
        # self.fail('Not implemented')