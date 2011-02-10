module Gmail2tracker
  class TrackerStory

    @@projects = {}
    @@stories = {}
    @@tracker_stories = {}

    def initialize name, description, project, story = nil
      @name = name
      @description = description
      @project = project
      @story = story
    end

    def create
      puts "saving story"
      @story = @project.stories.create(self.to_params)
      p @story
    end

    def update message
      note = @story.notes.create( :text => message.link ) if create_note? message.body
      p note
    end

    def create_note? text
      return false
      @notes ||= @story.notes.all.map(&:text)
      p @notes
      @notes << @description
      !@notes.include? text
    end

    def to_params
      {
        :name => @name,
        :description => @description,
        :story_type => 'bug'
      }
    end

    class << self
      def create_or_update message_array
        message_array.each do |message|
          puts message.subject
          if story = find( message )
            puts "updating story"
            # story ist hier pt story, soll aber nicht
            #story.update message
          else
            puts "creating story"
            create message
          end
          message.mark_tracked!
        end
      end

      def create message
        p message
        @@tracker_stories[message.subject] = new( message.subject, message.link, project(message) ).create
      end

      def find message
        return @@tracker_stories[message.subject] if @@tracker_stories[message.subject]
        p project(message)
        project = project(message)
        # extrem caching
        story = @@stories[message.subject] ||= begin
                                         stories = @@stories[project.id] ||= project.stories.all
                                         stories.find do |story|
                                           story.name == message.subject
                                         end
                                       end
        p story
        load_story story, project
      end

      def load_story story, project=nil
        return unless story
        @@tracker_stories[story.name] = new(story.name, story.description, project, story)
      end

      def project_client
        PivotalTracker::Project
      end

      def project message
        @@projects[:all] ||= project_client.all
        p @@projects[:all].map(&:name)
        p message.labels
        @@projects[message] ||= @@projects[:all].find do |project|
          message.labels.include? project.name
        end
      end
    end

  end
end
