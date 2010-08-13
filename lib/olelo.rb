# -*- coding: utf-8 -*-

require 'logger'
require 'cgi'
require 'digest/md5'
require 'digest/sha2'
require 'open3'
require 'set'
require 'yaml'
require 'nokogiri'
require 'mimemagic'
require 'haml'

require 'olelo/compatibility'
require 'olelo/extensions'
require 'olelo/util'
require 'olelo/i18n'
require 'olelo/hooks'
require 'olelo/timer'
require 'olelo/config'
require 'olelo/routing'
require 'olelo/user'
require 'olelo/fs'
require 'olelo/templates'
require 'olelo/helper'
require 'olelo/resource'
require 'olelo/plugin'
require 'olelo/patch'
require 'olelo/application'
