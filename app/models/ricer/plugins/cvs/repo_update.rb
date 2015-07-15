module Ricer::Plugins::Cvs
  class RepoUpdate
    
    # self.table_name = :cvs_repo_updates

    attr_accessor :revision, :comment, :commiter, :date
    
    def initialize(revision, commiter, date, comment)
      self.revision = revision
      self.commiter = commiter
      self.date = date
      self.comment = comment
    end
    
    def display_revision
      self.revision[0..8]
    end
    
  end
end