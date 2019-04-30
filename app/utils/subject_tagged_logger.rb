class SubjectTaggedLogger
  def initialize(logger, subject)
    @logger = ActiveSupport::TaggedLogging.new(logger)
    @subject = subject
  end

  def info(msg)
    @logger.tagged(*fomatted_subject) { @logger.info(msg) }
  end

  def warn(msg)
    @logger.tagged(*fomatted_subject) { @logger.warn(msg) }
  end

  def debug(msg)
    @logger.tagged(*fomatted_subject) { @logger.debug(msg) }
  end

  def error(msg)
    @logger.tagged(*fomatted_subject) { @logger.error(msg) }
  end

  private

  def fomatted_subject
    [Time.now.strftime('%Y-%m-%d %H:%M:%S.%L'), @subject.id, @subject.name]
  end
end