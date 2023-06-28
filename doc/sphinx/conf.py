#!/usr/bin/env python3
##########################################################################
##         #   The Coq Proof Assistant / The Coq Development Team       ##
##  v      #         Copyright INRIA, CNRS and contributors             ##
## <O___,, # (see version control and CREDITS file for authors & dates) ##
##   \VV/  ###############################################################
##    //   #    This file is distributed under the terms of the         ##
##         #     GNU Lesser General Public License Version 2.1          ##
##         #     (see LICENSE file for the text of the license)         ##
##########################################################################
#
# Coq documentation build configuration file, created by
# sphinx-quickstart on Wed May 11 11:23:13 2016.
#
# This file is execfile()d with the current directory set to its
# containing dir.
#
# Note that not all possible configuration values are present in this
# autogenerated file.
#
# All configuration values have a default; values that are commented out
# serve to show the default.

import sys
import os
from shutil import copyfile
import sphinx

# Increase recursion limit for sphinx
sys.setrecursionlimit(3000)

# If extensions (or modules to document with autodoc) are in another directory,
# add these directories to sys.path here. If the directory is relative to the
# documentation root, use os.path.abspath to make it absolute, like shown here.
sys.path.append(os.path.abspath('../tools/'))
sys.path.append(os.path.abspath('../../config/'))

# Disable the correct_copyright_year misfeature from Sphinx
# See https://github.com/coq/coq/issues/7378
sphinx.config.correct_copyright_year = lambda *args, **kwargs: None

import coq_config

# -- Prolog ---------------------------------------------------------------

# Include substitution definitions in all files
with open("refman-preamble.rst") as s:
    rst_prolog = s.read()

# -- General configuration ------------------------------------------------

# If your documentation needs a minimal Sphinx version, state it here.
needs_sphinx = '4.5.0'

# Add any Sphinx extension module names here, as strings. They can be
# extensions coming with Sphinx (named 'sphinx.ext.*') or your custom
# ones.
extensions = [
    'sphinx.ext.ifconfig',
    'sphinx.ext.mathjax',
    'sphinx.ext.todo',
    'sphinxcontrib.bibtex',
    'coqrst.coqdomain'
]

# Change this to "info" or "warning" to get notifications about undocumented Coq
# objects (objects with no contents).
report_undocumented_coq_objects = "warning"

# Add any paths that contain templates here, relative to this directory.
templates_path = ['_templates']

# The suffix(es) of source filenames.
# You can specify multiple suffix as a list of string:
# source_suffix = ['.rst', '.md']
source_suffix = '.rst'

# The encoding of source files.
#source_encoding = 'utf-8-sig'

# Add extra cases here to support more formats

SUPPORTED_FORMATS = ["html", "latex"]

def readbin(fname):
    try:
        with open(fname, mode="rb") as f:
            return f.read()
    except FileNotFoundError:
        return None

def copy_formatspecific_files(app):
    ext = ".{}.rst".format(app.builder.name)
    for fname in sorted(os.listdir(app.srcdir)):
        if fname.endswith(ext):
            src = os.path.join(app.srcdir, fname)
            dst = os.path.join(app.srcdir, fname[:-len(ext)] + ".rst")
            logger = sphinx.util.logging.getLogger(__name__)
            if readbin(src) == readbin(dst):
                logger.info("Skipping {}: {} is up to date".format(src, dst))
            else:
                logger.info("Copying {} to {}".format(src, dst))
                copyfile(src, dst)

def setup(app):
    app.connect('builder-inited', copy_formatspecific_files)
    app.add_config_value('is_a_released_version', coq_config.is_a_released_version, 'env')

# The master toctree document.
# We create this file in `copy_master_doc` above.
master_doc = "index"

# General information about the project.
project = 'Coq'
copyright = '1999-2021, Inria, CNRS and contributors'
author = 'The Coq Development Team'

# The version info for the project you're documenting, acts as replacement for
# |version| and |release|, also used in various other places throughout the
# built documents.
#
# The short X.Y version.
version = coq_config.version
# The full version, including alpha/beta/rc tags.
release = coq_config.version

# The language for content autogenerated by Sphinx. Refer to documentation
# for a list of supported languages.
#
# This is also used if you do content translation via gettext catalogs.
# Usually you set "language" from the command line for these cases.
language = 'en'

# There are two options for replacing |today|: either, you set today to some
# non-false value, then it is used:
#today = ''
# Else, today_fmt is used as the format for a strftime call.
#today_fmt = '%B %d, %Y'

# List of patterns, relative to source directory, that match files and
# directories to ignore when looking for source files.
# This patterns also effect to html_static_path and html_extra_path
exclude_patterns = [
    '_build',
    'Thumbs.db',
    '.DS_Store',
    'introduction.rst',
    'refman-preamble.rst',
    'README.rst',
    'README.gen.rst',
    'README.template.rst'
] + ["*.{}.rst".format(fmt) for fmt in SUPPORTED_FORMATS]

# The reST default role (used for this markup: `text`) to use for all
# documents.
default_role = 'literal'

# Use the Coq domain
primary_domain = 'coq'

# If true, '()' will be appended to :func: etc. cross-reference text.
#add_function_parentheses = True

# If true, the current module name will be prepended to all description
# unit titles (such as .. function::).
#add_module_names = True

# If true, sectionauthor and moduleauthor directives will be shown in the
# output. They are ignored by default.
#show_authors = False

# The name of the Pygments (syntax highlighting) style to use.
pygments_style = 'sphinx'
highlight_language = 'text'
suppress_warnings = ["misc.highlighting_failure"]

# A list of ignored prefixes for module index sorting.
#modindex_common_prefix = []

# If true, keep warnings as "system message" paragraphs in the built documents.
#keep_warnings = False

# If true, `todo` and `todoList` produce output, else they produce nothing.
todo_include_todos = False

# Extra warnings, including undefined references
nitpicky = True

# -- Options for HTML output ----------------------------------------------

# The theme to use for HTML and HTML Help pages.  See the documentation for
# a list of builtin themes.
html_theme = 'sphinx_rtd_theme'
# html_theme = 'agogo'
# html_theme = 'alabaster'
# html_theme = 'haiku'
# html_theme = 'bizstyle'

# Theme options are theme-specific and customize the look and feel of a theme
# further.  For a list of options available for each theme, see the
# documentation.
PDF_URL = "https://github.com/coq/coq/releases/download/V{version}/coq-{version}-reference-manual.pdf"
html_theme_options = {
    'collapse_navigation': False
}
html_context = {
    'display_github': True,
    'github_user': 'coq',
    'github_repo': 'coq',
    'github_version': 'master',
    'conf_py_path': '/doc/sphinx/',
    # Versions and downloads listed in the versions menu (see _templates/versions.html)
    'versions': [
        ("dev", "https://coq.github.io/doc/master/refman/"),
        ("stable", "https://coq.inria.fr/distrib/current/refman/"),
        ("8.17", "https://coq.github.io/doc/v8.17/refman/"),
        ("8.16", "https://coq.inria.fr/distrib/V8.16.1/refman/"),
        ("8.15", "https://coq.inria.fr/distrib/V8.15.2/refman/"),
        ("8.14", "https://coq.inria.fr/distrib/V8.14.1/refman/"),
        ("8.13", "https://coq.inria.fr/distrib/V8.13.2/refman/"),
        ("8.12", "https://coq.inria.fr/distrib/V8.12.2/refman/"),
        ("8.11", "https://coq.inria.fr/distrib/V8.11.2/refman/"),
        ("8.10", "https://coq.inria.fr/distrib/V8.10.2/refman/"),
        ("8.9", "https://coq.inria.fr/distrib/V8.9.1/refman/"),
        ("8.8", "https://coq.inria.fr/distrib/V8.8.2/refman/"),
        ("8.7", "https://coq.inria.fr/distrib/V8.7.2/refman/"),
        ("8.6", "https://coq.inria.fr/distrib/V8.6.1/refman/"),
        ("8.5", "https://coq.inria.fr/distrib/V8.5pl3/refman/"),
        ("8.4", "https://coq.inria.fr/distrib/V8.4pl6/refman/"),
        ("8.3", "https://coq.inria.fr/distrib/V8.3pl5/refman/"),
        ("8.2", "https://coq.inria.fr/distrib/V8.2pl3/refman/"),
        ("8.1", "https://coq.inria.fr/distrib/V8.1pl6/refman/"),
        ("8.0", "https://coq.inria.fr/distrib/V8.0/doc/")
    ],
    'downloads': ([("PDF", PDF_URL.format(version=version))]
                  if coq_config.is_a_released_version else [])
}

# Add any paths that contain custom themes here, relative to this directory.
import sphinx_rtd_theme
html_theme_path = [sphinx_rtd_theme.get_html_theme_path()]

# The name for this set of Sphinx documents.
# "<project> v<release> documentation" by default.
#html_title = 'Coq 8.5 v8.5pl1'

# A shorter title for the navigation bar.  Default is the same as html_title.
#html_short_title = None

# The name of an image file (relative to this directory) to place at the top
# of the sidebar.
#html_logo = None

# The name of an image file (relative to this directory) to use as a favicon of
# the docs.  This file should be a Windows icon file (.ico) being 16x16 or 32x32
# pixels large.
#html_favicon = None

# Add any paths that contain custom static files (such as style sheets) here,
# relative to this directory. They are copied after the builtin static files,
# so a file named "default.css" will overwrite the builtin "default.css".
html_static_path = ['_static']

# Add any extra paths that contain custom files (such as robots.txt or
# .htaccess) here, relative to this directory. These files are copied
# directly to the root of the documentation.
#html_extra_path = []

# If not None, a 'Last updated on:' timestamp is inserted at every page
# bottom, using the given strftime format.
# The empty string is equivalent to '%b %d, %Y'.
#html_last_updated_fmt = None

# FIXME: this could be re-enabled after ensuring that smart quotes are locally
# disabled for all relevant directives
smartquotes = False

# Custom sidebar templates, maps document names to template names.
#html_sidebars = {}

# Additional templates that should be rendered to pages, maps page names to
# template names.
#html_additional_pages = {}

# If false, no module index is generated.
#html_domain_indices = True

# If false, no index is generated.
#html_use_index = True

# If true, the index is split into individual pages for each letter.
#html_split_index = False

# If true, links to the reST sources are added to the pages.
#html_show_sourcelink = True

# If true, "Created using Sphinx" is shown in the HTML footer. Default is True.
#html_show_sphinx = True

# If true, "(C) Copyright ..." is shown in the HTML footer. Default is True.
#html_show_copyright = True

# If true, an OpenSearch description file will be output, and all pages will
# contain a <link> tag referring to it.  The value of this option must be the
# base URL from which the finished HTML is served.
#html_use_opensearch = ''

# This is the file name suffix for HTML files (e.g. ".xhtml").
#html_file_suffix = None

# Language to be used for generating the HTML full-text search index.
# Sphinx supports the following languages:
#   'da', 'de', 'en', 'es', 'fi', 'fr', 'h', 'it', 'ja'
#   'nl', 'no', 'pt', 'ro', 'r', 'sv', 'tr', 'zh'
#html_search_language = 'en'

# A dictionary with options for the search language support, empty by default.
# 'ja' uses this config value.
# 'zh' user can custom change `jieba` dictionary path.
#html_search_options = {'type': 'default'}

# The name of a javascript file (relative to the configuration directory) that
# implements a search results scorer. If empty, the default will be used.
#html_search_scorer = 'scorer.js'

# -- Options for LaTeX output ---------------------------------------------

###########################
# Set things up for XeTeX #
###########################

latex_elements = {
    'babel': '',
    'fontenc': '',
    'inputenc': '',
    'utf8extra': '',
    'cmappkg': '',
    'papersize': 'letterpaper',
    'classoptions': ',openany', # No blank pages
    'polyglossia': '\\usepackage{polyglossia}',
    'sphinxsetup': 'verbatimwithframe=false',
    'preamble': r"""
                 \usepackage{unicode-math}
                 \usepackage{microtype}

                 % Macro definitions
                 \usepackage{refman-preamble}

                 % Style definitions for notations
                 \usepackage{coqnotations}

                 % Style tweaks
                 \newcssclass{sigannot}{\textrm{#1:}}

                 % Silence 'LaTeX Warning: Command \nobreakspace invalid in math mode'
                 \everymath{\def\nobreakspace{\ }}
                 """
}

latex_engine = "xelatex"

# Cf. https://github.com/sphinx-doc/sphinx/issues/7015
latex_use_xindy = False

########
# done #
########

latex_additional_files = [
    "refman-preamble.sty",
    "_static/coqnotations.sty"
]

latex_documents = [('index', 'CoqRefMan.tex', 'The Coq Reference Manual', author, 'manual')]

# The name of an image file (relative to this directory) to place at the top of
# the title page.
# latex_logo = "../../ide/coq.png"

# If true, show page references after internal links.
#latex_show_pagerefs = False

# If true, show URL addresses after external links.
latex_show_urls = 'footnote'

# -- Options for manual page output ---------------------------------------

# One entry per manual page. List of tuples
# (source start file, name, description, authors, manual section).
#man_pages = [
#    (master_doc, 'coq', 'Coq Documentation',
#     [author], 1)
#]

# If true, show URL addresses after external links.
#man_show_urls = False


# -- Options for Texinfo output -------------------------------------------

# Grouping the document tree into Texinfo files. List of tuples
# (source start file, target name, title, author,
#  dir menu entry, description, category)
#texinfo_documents = [
#    (master_doc, 'Coq', 'Coq Documentation',
#     author, 'Coq', 'One line description of project.',
#     'Miscellaneous'),
#]

# Documents to append as an appendix to all manuals.
#texinfo_appendices = []

# If false, no module index is generated.
#texinfo_domain_indices = True

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#texinfo_show_urls = 'footnote'

# If true, do not generate a @detailmenu in the "Top" node's menu.
#texinfo_no_detailmenu = False


# -- Options for Epub output ----------------------------------------------

# Bibliographic Dublin Core info.
#epub_title = project
#epub_author = author
#epub_publisher = author
#epub_copyright = copyright

# The basename for the epub file. It defaults to the project name.
#epub_basename = project

# The HTML theme for the epub output. Since the default themes are not
# optimized for small screen space, using the same theme for HTML and epub
# output is usually not wise. This defaults to 'epub', a theme designed to save
# visual space.
#epub_theme = 'epub'

# The language of the text. It defaults to the language option
# or 'en' if the language is not set.
#epub_language = ''

# The scheme of the identifier. Typical schemes are ISBN or URL.
#epub_scheme = ''

# The unique identifier of the text. This can be a ISBN number
# or the project homepage.
#epub_identifier = ''

# A unique identification for the text.
#epub_uid = ''

# A tuple containing the cover image and cover page html template filenames.
#epub_cover = ()

# A sequence of (type, uri, title) tuples for the guide element of content.opf.
#epub_guide = ()

# HTML files that should be inserted before the pages created by sphinx.
# The format is a list of tuples containing the path and title.
#epub_pre_files = []

# HTML files that should be inserted after the pages created by sphinx.
# The format is a list of tuples containing the path and title.
#epub_post_files = []

# A list of files that should not be packed into the epub file.
epub_exclude_files = ['search.html']

# The depth of the table of contents in toc.ncx.
#epub_tocdepth = 3

# Allow duplicate toc entries.
#epub_tocdup = True

# Choose between 'default' and 'includehidden'.
#epub_tocscope = 'default'

# Fix unsupported image types using the Pillow.
#epub_fix_images = False

# Scale large images.
#epub_max_image_width = 0

# How to display URL addresses: 'footnote', 'no', or 'inline'.
#epub_show_urls = 'inline'

# If false, no index is generated.
#epub_use_index = True

# navtree options
navtree_shift = True

# since sphinxcontrib-bibtex version 2 we need this
bibtex_bibfiles = [ "biblio.bib" ]
