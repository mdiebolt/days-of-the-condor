desc "build page"
task :build do
  `bundle exec middleman build`
end

desc "change to gh-pages branch"
task :checkout_pages do
  `git checkout gh-pages`
end

desc "change to master branch"
task :checkout_master do
  `git checkout master`
end

desc "clean up"
task :cleanup do
  `rm -rf build/`
end

desc "move files to root level"
task :move_files do
  `mv build/* .`
end

desc "push to github"
task :push do
  `git c -am 'build'`
  `git push origin master`
end

desc "deploy page to github"
task :deploy => [:cleanup, :build, :checkout_pages, :move_files, :push, :checkout_master]
