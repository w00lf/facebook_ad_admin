module NetUtils
  module_function

  def file_name_with_extention(url)
    Pathname.new(URI(url).path).basename.to_s
  end

  def download(url, default_extention = 'jpg')
    data = Net::HTTP.get(URI(url))
    base,extention = file_name_with_extention(url).split('.')
    extention = default_extention if extention.nil?
    file = Tempfile.new([base,".#{extention}"])
    file.binmode
    file.write(data)
    file.rewind
    file
  end
end