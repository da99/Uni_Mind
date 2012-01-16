
FOLDER = "/tmp/Uni_Mind"

`rm -rf #{FOLDER}`
`cp -r  spec/Boxes #{FOLDER}`

Dir.chdir "#{FOLDER}/Mind"
ENV['SKIP_IP_CHECK'] = 'true'
puts `bundle exec UNI_MIND ALL servers upload_templates 2>&1`
