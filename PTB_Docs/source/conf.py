# Configuration file for the Sphinx documentation builder.
#
# This file only contains a selection of the most common options. For a full
# list see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Path setup --------------------------------------------------------------

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
#
import os
import sys
import datetime
sys.path.insert(0, os.path.abspath('.'))


# -- Project information -----------------------------------------------------

project = 'Psych Toolbar'
now     = datetime.datetime.now()       # Get current date
author  = 'New Atlantis Labs'
copyright = '%d, %s' % (now.year, author)
version = '1.0'                     # The short X.Y version
release = '1.0'                     # The full version, including alpha/beta/rc tags


# -- General configuration ---------------------------------------------------

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.todo',
    'sphinx.ext.githubpages',
    #'recommonmark',
    # 'zot4rst.sphinx',
    'sphinx.ext.intersphinx',
    #'sphinx_inline_tabs',
    'sphinx_panels',
    'sphinx_design',
    'matplotlib.sphinxext.plot_directive',
    'sphinx_copybutton',
    #'sphinx_wagtail_theme',
    'sphinx_book_theme',
    #'sphinx_tippy',
    #'sphinxcontrib.video',
]

todo_include_todos = True

# Add any paths that contain templates here, relative to this directory.
#templates_path = ['_templates']

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This pattern also affects html_static_path and html_extra_path.
exclude_patterns = []

# The master toctree document.
master_doc = 'index'

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'monokai' #'sphinx'

# -- Options for HTML output -------------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
#

html_theme = 'sphinx_book_theme'
#html_theme = 'sphinx_wagtail_theme'
#html_theme = 'nature'
#html_theme = 'sphinx_material'

html_logo = './_images/Logos/PTB_LogoSide_b.png'

#============== Options specific to 'Book' Sphinx theme
# See https://sphinx-book-theme.readthedocs.io/en/stable/tutorials/get-started.html

if html_theme == 'sphinx_book_theme':
    html_theme_options = {
        "repository_url": "https://github.com/Phenomenal-Cat/PsychToolbar",
        "use_repository_button": True,
    }
    
    html_title = 'Psych Toolbar'

    html_theme_options = {
       "logo": {
          "alt_text": "PsychToolbar - Home",
          "image_light": "./_images/Logos/PTB_LogoSide_b.png",
          "image_dark": "./_images/Logos/PTB_LogoSide_w.png",
       }
    }



#============== Options specific to 'Wagtail' Sphinx theme
# See https://sphinx-wagtail-theme.readthedocs.io/en/latest/customizing.html

if html_theme == 'sphinx_wagtail_theme':
    html_theme_options = dict(
        project_name = "Psych Toolbar",
        logo = '_images/PTB_Logo_w.png',
        logo_alt = 'PsychToolbar',
        logo_height = 50,
        logo_width = 80,
        logo_url = "/",
    )
    html_theme_options = dict(
        github_url = "https://github.com/Phenomenal-Cat/PsychToolbar/tree/main/PTB_Docs/"
    )
    html_theme_options = dict(
        header_links = "Home|http://psychtoolbar.rtfd.io/, NA|http://newatlantis.rtfd.io/",
        footer_links = ",".join([
            "New Atlantis Labs|http://newatlantis.rtfd.io/",
        ]),
     )
    html_show_copyright = False
    html_show_sphinx    = False


#============== Options specific to 'nature' Sphinx theme
if html_theme == 'nature':
    html_title              = 'Psych Toolbar'
    html_short_title        = 'PsychToolbar'
    html_logo               = './_images/Logos/PTB_Logo_w.png'
    html_show_sourcelink    = False
    

#html_favicon           = './_images/Logos/NIF_favicon.ico'


# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# Custom sidebar templates, must be a dictionary that maps document names
# to template names.
#
# The default sidebars (for documents that don't match any pattern) are
# defined by theme itself.  Builtin themes are using these templates by
# default: ``['localtoc.html', 'relations.html', 'sourcelink.html',
# 'searchbox.html']``.
#

html_sidebars = { '**': ['globaltoc.html', 'relations.html', 'sourcelink.html', 'searchbox.html'] }

# Custom CSS
html_css_files = [
    #'css/nif.css',
    'css/custom.css',
    'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.2/css/all.min.css',
]
