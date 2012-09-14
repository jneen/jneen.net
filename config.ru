load File.join(File.dirname(__FILE__), 'app/app.rb')
require 'rake-pipeline/middleware'

use Rake::Pipeline::Middleware, 'Assetfile'
run BlagApp
