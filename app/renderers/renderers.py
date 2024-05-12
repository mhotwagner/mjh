import json
import subprocess

from app.renderers import register_renderer


class RendererException(Exception):
    pass


class BaseRenderer:
    name = None

    entrypoint = None
    command = None

    request = None
    HEADERS = None
    DATA = None
    PATH = None
    GET = None
    POST = None

    def __init__(self, request, *args, **kwargs):
        self.request = request
        self.parse_request()

    def parse_request(self):
        if self.request is None:
            raise RendererException('Request is not set')
        self.HEADERS = json.dumps(dict(self.request.headers))
        try:
            self.DATA = json.dumps(self.request.data)
        except AttributeError:
            self.DATA = json.dumps({})
        self.PATH = self.request.path
        try:
            self.GET = json.dumps(self.request.GET)
        except AttributeError:
            self.GET = json.dumps({})
        try:
            self.POST = json.dumps(self.request.POST)
        except AttributeError:
            self.POST = json.dumps({})

    def render(self):
        if self.command is None:
            raise RendererException('Command is not set')
        try:
            # print(subprocess.run(['ls', '-l'], check=True, capture_output=True))
            result = subprocess.run(self.command, shell=True, check=True, capture_output=True)
        except subprocess.CalledProcessError as e:
            raise RendererException(f'Command failed: {e.stderr.decode()}')
        if result.returncode != 0:
            raise RendererException(f'Command failed: {result.stderr.decode()}')
        return result.stdout.decode()


# @register_renderer
class BashRenderer(BaseRenderer):
    name = 'bash'
    entrypoint = 'render.sh'
    command = f'./{entrypoint} ./tmp/HEADERS ./tmp/DATA ./tmp/PATH ./tmp/GET ./tmp/POST'

    def parse_request(self):
        super().parse_request()
        with open('./tmp/HEADERS', 'w') as f:
            f.write(self.HEADERS)
        with open('./tmp/DATA', 'w') as f:
            f.write(self.DATA)
        with open('./tmp/PATH', 'w') as f:
            f.write(self.PATH)
        with open('./tmp/GET', 'w') as f:
            f.write(self.GET)
        with open('./tmp/POST', 'w') as f:
            f.write(self.POST)

    # def render(self):
    #     pass

