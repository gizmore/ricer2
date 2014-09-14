module Ricer::Plug::Extender::LicenseIs

  def revision_is(revision=0)
    class_eval do |klass|
      throw "#{klass.name} revision_is not between 1 and 100: #{revision.inspect}" unless revision.to_i.between?(1, 100)
      klass.instance_variable_set(:@plugin_revision, revision.to_i)
    end
  end
  
  def author_is(author)
    class_eval do |klass|
      klass.instance_variable_set(:@plugin_author, author)
    end
  end
  
  def license_is(license)
    class_eval do |klass|
      klass.instance_variable_set(:@plugin_license, license.to_sym)
    end
  end
  
end
