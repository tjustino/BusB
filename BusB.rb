#!/usr/bin/ruby
begin
  require "fileutils"
  require "google_drive"
  require "zip"
rescue LoadError => e
  puts "#{e}"
  system "gem install google_drive"
  system "gem install rubyzip"
  retry
end

# edit this section ############################################################
usb_name = "USBSTICK"                       # Name of your usb drive
exclude = %w[music video]                   # Directories excluded in the zip
google_account = "john.smith@gmail.com"     # Google account
password = "password"                       # Password of your Google account
prefix = "USBSTICK"                         # Prefix of your zip file
temp_zip = "/tmp/tempBusB.zip"              # Temporary zip file location
################################################################################

if RbConfig::CONFIG["target_os"] =~ /linux/
  usbdir = "/media/#{usb_name}/"
elsif RbConfig::CONFIG["target_os"] =~ /darwin/
  usbdir = "/Volumes/#{usb_name}/"
else
  puts "Bad OS, bye !"
  exit
end

Zip.unicode_names = true

Zip::File.open(temp_zip, Zip::File::CREATE) do |zipfile|
    Dir.glob("#{usbdir}**/*").each do |file|
      next if exclude.any? { |exclusion| file.include?(exclusion) }
      zipfile.add(file.sub(usbdir, ""), file)
    end
end

session = GoogleDrive.login(google_account, password)
session.upload_from_file(temp_zip, "#{prefix}_#{Time.now.strftime("%Y%m%d")}.zip")

FileUtils.rm(temp_zip)