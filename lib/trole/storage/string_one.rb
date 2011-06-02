module Trole::Storage
  class StringOne < Generic        
    def initialize role_subject        
      super
    end

    # saves the role for the user in the data store
    def set_role role
      set_ds_field role.to_s
    end  

    # clears the role of the user in the data store
    def set_default_role!
      set_ds_field ""
    end  
  end
end