# A sample Guardfile
# More info at https://github.com/guard/guard#readme
notification :off

guard :minitest, :bundler => false do
  # Watch all exercise files and run their respective test
  watch(%r{^lib/(.+)\.rb}) { |m| "test/#{m[1]}_test.rb" }
  watch(%r{^(test/.+\.rb)}) { |m| "#{m[1]}" }
end