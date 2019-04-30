class SubjectFormatter < ::Logger::Formatter
  def call(severity, timestamp, _progname, msg)
    # `sprintf` formats string
    # https://apidock.com/ruby/Kernel/sprintf
    formatted_severity = format('%-5s', severity.to_s)

    # `%L`to display milliseconds
    # http://ruby-doc.org/core-2.1.5/Time.html#method-i-strftime
    formatted_time = timestamp.strftime('%Y-%m-%d %H:%M:%S.%L')

    # Double dollar sign is the current process ID: important for multithreading !
    # http://ruby-doc.org/core-2.3.1/doc/globals_rdoc.html
    "[#{$PROCESS_ID}] #{formatted_time} #{formatted_severity}| #{msg}\n"
  end
end