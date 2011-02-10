module Gmail
  class Labels

    # only need user defined labels
    def all
      conn.list("", "%").inject([]) do |labels,label|
        label[:name].each_line {|l| labels << Net::IMAP.decode_utf7(l) }
        labels 
      end
    end
  end

  # for german googlemail.com accounts
  class Message
    def archive!
      move_to('[Google Mail]/Alle Nachrichten')
    end

    # dont delete
    def move_to(name, from=nil)
      label(name, from)
      @mailbox.messages.delete(uid)
      flag(:deleted)
      #delete! if !%w[[Gmail]/Bin [Gmail]/Trash].include?(name)
    end
  end

end
