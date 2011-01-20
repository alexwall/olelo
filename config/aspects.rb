# Filter aspect configuration aspects.rb

################################################################################
#
# Register some simple regular expression filters which are used later
#
# Usage:
#   regexp :filter_name, /regex1/, 'replacement1', /regex2/, 'replacement2'
#
################################################################################

regexp :remove_comments, /<!--.*?-->/m,         ''
regexp :tag_shortcuts,   /\\\((.*?)\\\)/m,      '<math display="inline">\1</math>',
                         /\\\[(.*?)\\\]/m,      '<math display="block">\1</math>',
                         /<<(.*?)(\|(.*?))?>>/, '<include page="\1" \3/>'
regexp :creole_nowiki,   /\{\{\{.*?\}\}\}/m,    '<notags>\0</notags>'
regexp :textile_nowiki,  /<pre>.*?<\/pre>/m,    '<notags>\0</notags>'

################################################################################
#
# Define filter aspects which process pages by sending them
# through multiple filters. DSL methods can be chained.
# Available filters are listed on the /system page.
#
# Example DSL usage:
#
# aspect :aspect_name do          # Create aspect with name "aspect_name"
#  is_cacheable                   # Aspect supports caching (renders static content)
#  needs_layout                   # Aspect needs a html layout around the generated content
#  has_priority 1                 # Aspect has priority 1, lower priorities are preferred
#  accepts 'text/x-creole'        # Accepted mime types. This is a regular expression
#  mime    'text/html'            # Generated mime type. Only interesting for aspects which don't need a layout.
#  filter do                      # Define filter chain
#    remove_comments              # First filter removes html comments <!--...-->. This filter is defined above.
#    tag_shortcuts                # Replace tag shortcuts with tags (e.g $$...$$ -> <math>...</math>, <<page>> -> <include page="page"/>)
#    creole_nowiki                # Replace creole nowiki tags with <notags> to disable tag interpretation (next filter)
#    tag do                       # Interpret wiki tags. Wiki tags are an extension to default wiki text
#      creole!                    # Transform creole to html
#      rubypants                  # Execute rubypants (e.g. replace ... with &hellip;)
#    end
#    toc                          # Auto-generate table of contents
#    link_classifier              # Classify links: Insert classes present for present pages, absent for absent pages, internal, external
#  end
# end
#
# tag filter options:
#   tag(:enable => 'html:*') Enable only html tags
#   tag(:disable => %w(html:* scripting:include)) Disable html tags and scripting:include
#   tag(:disable => 'html:*') Disable only html tags
#
################################################################################

interwiki_map = YAML.load_file(File.join(Config['config_path'], 'interwiki.yml'))

################################################################################
# Creole aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(1)
  accepts 'text/x-creole'
  filter do
    editsection do
      remove_comments.tag_shortcuts
      creole_nowiki.tag { creole!.rubypants }
    end
    toc.interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-creole'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts
    creole_nowiki.tag { creole!.rubypants }
    toc.interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-creole'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.creole_nowiki
    tag(:static => true) { creole!.rubypants }
    toc.interwiki(:map => interwiki_map)
    html_wrapper!.xslt!(:stylesheet => 'xhtml2latex.xsl')
  end
end

################################################################################
# Textile aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(1)
  accepts 'text/x-textile'
  filter do
    remove_comments.tag_shortcuts.textile_nowiki
    tag(:disable => 'html:*') { textile!.rubypants }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-textile'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.textile_nowiki
    tag(:disable => 'html:*') { textile!.rubypants }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-textile'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.textile_nowiki
    tag(:static => true, :disable => 'html:*') { textile!.rubypants }
    toc.interwiki(:map => interwiki_map)
    html_wrapper!.xslt!(:stylesheet => 'xhtml2latex.xsl')
  end
end

################################################################################
# Markdown aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(1)
  accepts 'text/x-markdown'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { markdown! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-markdown'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { markdown! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-markdown'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:static => true, :disable => 'html:*') { markdown! }
    toc.interwiki(:map => interwiki_map)
    html_wrapper!.xslt!(:stylesheet => 'xhtml2latex.xsl')
  end
end

################################################################################
# Kramdown aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(2)
  accepts 'text/x-markdown(\.kramdown)?'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { kramdown! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-markdown(\.kramdown)?'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { kramdown! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-markdown(\.kramdown)?'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:static => true, :disable => 'html:*') { kramdown!(:latex => true) }
  end
end

################################################################################
# Maruku aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(3)
  accepts 'text/x-markdown(\.maruku)?'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { maruku! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-markdown(\.maruku)?'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:disable => 'html:*') { maruku! }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-markdown(\.maruku)?'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts.markdown_nowiki
    tag(:static => true, :disable => 'html:*') { maruku! }
    toc.interwiki(:map => interwiki_map)
    html_wrapper!.xslt!(:stylesheet => 'xhtml2latex.xsl')
  end
end

################################################################################
# Orgmode aspects configuration
################################################################################

aspect :page do
  is_cacheable.needs_layout.has_priority(1)
  accepts 'text/x-orgmode'
  filter do
    remove_comments.tag_shortcuts
    tag { orgmode!.rubypants }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
  end
end

aspect :s5 do
  is_cacheable
  accepts 'text/x-orgmode'
  mime 'application/xhtml+xml; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts
    tag { orgmode!.rubypants }
    fix_img_tag.toc
    interwiki(:map => interwiki_map).link_classifier
    html_wrapper!.s5!
  end
end

aspect :latex do
  is_cacheable
  accepts 'text/x-orgmode'
  mime 'text/plain; charset=utf-8'
  filter do
    remove_comments.tag_shortcuts
    tag(:static => true) { orgmode!.rubypants }
    toc.interwiki(:map => interwiki_map)
    html_wrapper!.xslt!(:stylesheet => 'xhtml2latex.xsl')
  end
end
