module NetUtils
  module_function

  def file_name_with_extention(url)
    Pathname.new(URI(url).path).basename.to_s
  end

  def download(url, default_extention = 'jpg')
    data = RestClient.get(format_url(url)).body
    base,extention = file_name_with_extention(url).split('.')
    extention = default_extention if extention.nil?
    file = Tempfile.new([base,".#{extention}"])
    file.binmode
    file.write(data)
    file.rewind
    file
  end

  def format_url(url)
    return google_download_url(url) if url =~ /drive.google.com/
    url
  end

  def google_download_url(url)
    hash = url.match(/https:\/\/drive.google.com\/file\/d\/(.+)\/view/)[1]
    "https://drive.google.com/uc?id=#{hash}&export=download"
  end
end