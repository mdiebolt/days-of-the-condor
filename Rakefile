desc "build page"
task :build do
  `git checkout master`
  `bundle exec middleman build`
  `mv build /blog/tmp/`
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
  `rm -rf /blog/tmp/`
  `mkdir /blog/tmp/`
end

desc "move files to root level"
task :move_files do
  `cp -r /blog/tmp/build/* .`
  `cp CNAME .`
end

desc "push to github"
task :push do
  `git commit -am 'Site updated at #{Time.now.utc}'`
  `git push origin gh-pages`
end

desc "deploy page to github"
task :deploy => [:cleanup, :build, :checkout_pages, :move_files, :push, :checkout_master]
