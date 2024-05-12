renderers = {}


def register_renderer(renderer):
    renderers[str(renderer.name).lower()] = renderer
