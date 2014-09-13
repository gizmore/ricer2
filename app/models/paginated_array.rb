class PaginatedArray < Array
  
  def initialize(copy_from=nil)
    self[0..copy_from.length] = copy_from if copy_from.is_a?(Array)
  end
  
  def visible
    self
  end
  
  
  
  
end