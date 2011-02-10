module Gmail2tracker
  class Message

    @@labels = nil
    @@gmail_client = nil

    attr_reader :subject, :body

    def initialize mail
      @subject = mail.subject.gsub(/\=\?UTF\-8\?Q\?/, '').gsub(/\?\=\ /, '').unpack 'M'
      @body = mail.body
      @mail = mail
      @uid = mail.message_id
    end

    def labels
      @labels ||= @@labels.select do |label|
        self.class.gmail.label(label).emails.map(&:subject).include? @mail.subject
      end
    end

    def link
      "https://mail.google.com/mail/u/1/#search/#{ @uid }"
    end

    def mark_tracked!
      @mail.read!
      @mail.archive!
    end

    class << self
      def fetch_new
        messages = []
        @@gmail_client = Gmail.connect *Gmail2tracker.gmail_credentials
        puts "found #{gmail.inbox.count} mails"
        fetch_labels
        gmail.inbox.all.each do |mail|
          messages << new( mail )
        end
        messages
      end

      def gmail
        @@gmail_client
      end

      def disconnect
        gmail.logout
      end

      def fetch_labels
        @@labels ||= gmail.labels.all.reject do |label|
          label =~ /Google/
        end
      end
    end
  end
end
