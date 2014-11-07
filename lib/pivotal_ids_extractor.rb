class PivotalIdsExtractor

  attr_accessor :source_text, :stories

  #  --- [#62749778] New Email Page --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development --- [#62749778] Roughed out email form. --- Added delete Attachment functionality --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development --- [#62749778] Refactored controller to be plural. --- [#62749778] Added to the Email model. --- [62749778] The email this report view formatting. --- [#62749778] Breadcrumbs in the navigation. --- [#62749778] The Emails controller routes. --- The report list is now sorted with newest first - and it shows how long ago that the change was made. --- [#62749778] The share link is bold. --- [#62749778] Recipient parsing and form fields --- [#62749778] List of emails that have received it. --- [#62749778] The email form will validate that at least one email is provided. --- [#62749778] Send Roof Report AJAX form. --- [#62749778] Default messages and the mailer --- [Finishes #62749778] The emails are sent! --- removed delete from show --- added txt and xpf to permitted file types --- Attachments can only be deleted by the owner of the roof report. --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development --- The test server is using production. --- Returns all recommended options across all sections with roof_report.recommedations --- patial commit --- Finished summary section --- Added caps to permitted --- added to_s to inspection --- E-mail spec is not focused at the moment. --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development --- fixed a few bugs --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development --- Disable ajax save. --- Merge branch 'development' of bitbucket.org:rietta/roofregistry-web into development
  # s = "[#62749778] [#62749778] [#6274977] [#1] [#231]"
  # m = s.scan /\[[A-Za-z ]{0,20}#[0-9]{1,20}\]/

  def initialize(text)
    stories = Array.new
    # Extract the unique ids between brackets
    if text
      # Require brackets
      #candidates = text.scan /\[[A-Za-z \t]{0,20}#[0-9]{1,35}[ \t]{0,5}\]/
      candidates = text.scan /[A-Za-z \t]{0,20}#[0-9]{1,35}[ \t]{0,5}/
      if candidates
        candidates.uniq.each do |story|
          story_num = story.match(/[0-9]{1,35}/).to_s.to_i
          stories << story_num if story_num > 0
        end
      end
    end
    @source_text  = text
    @stories      = stories.sort
  end


end