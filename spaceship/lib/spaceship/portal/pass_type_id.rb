module Spaceship
  module Portal
    # Represents an identifier from the Apple Developer Portal
    class PassTypeId < PortalBase
      # @return (String) The ID given from the developer portal.
      # @example
      #   "H7V684NAVZ"
      attr_accessor :id

      # @return (String) The name of the pass type ID
      # @example
      #   "My Sweet Pass Type ID"
      attr_accessor :name

      # @return (String) The actual identifier for the pass type ID
      # @example
      #   "pass.com.example.ticket"
      attr_accessor :identifier

      # @return (String) The prefix for the pass type ID. Appears that this is
      # just the current team id
      # @example
      #   "ABC3456789"
      attr_accessor :prefix

      # @return (String) Status of the pass type ID
      # @example
      #   "current"
      attr_accessor :status

      # @return (Bool) Whether or not the pass type ID can be edited
      # (Can be null)
      attr_accessor :can_edit

      # @return (Bool) Whether or not the pass type ID can be deleted
      # (Can be null)
      attr_accessor :can_delete
      #
      # @return (String) The display ID given from the developer portal. Is
      #  exactly the same as id. Though it's only set by the `pass_type_ids`
      #  response (id is not set in this case)
      # @example
      #   "H7V684NAVZ"
      attr_accessor :display_id

      attr_mapping({
        'passTypeId' => :id,
        'name' => :name,
        'identifier' => :identifier,
        'prefix' => :prefix,
        'status' => :status,
        'shoeboxId' => :id,
        'displayId' => :display_id,
        'canEdit' => :can_edit,
        'canDelete' => :can_delete
      })

      class << self
        # Create a new object based on a hash.
        # This is used to create a new object based on the server response.
        def factory(attrs)
          self.new(attrs)
        end

        # @return (Array) Returns all pass type IDs registered for this account
        def all
          client.pass_type_ids.map { |pass_type_id| self.factory(pass_type_id) }
        end

        # @return (PassTypeID) Find a pass type ID based on the identifier of the
        # pass_type_id. nil if no device was found.
        def find_by_identifier(identifier)
          all.find do |pass_type_id|
            pass_type_id.identifier == identifier
          end
        end

        # @return (PassTypeID) Find a pass type ID based on the id of the
        # pass_type_id. nil if no device was found.
        def find(id)
          all.find do |pass_type_id|
            pass_type_id.display_id == id
          end
        end

        # Register a new device to this account
        # @param identifier (String) (required): The identifier of the
        #   pass type ID
        # @example
        #   Spaceship.pass_type_id.create!(identifier: "pass.com.example.ticket")
        # @return (PassTypeID): The newly created pass type ID
        def create!(name: nil, identifier: nil)
          # Check whether the user has passed in a UDID and a name
          unless name && identifier
            raise "You cannot create a pass type ID without a name and an identifier"
          end

          # Find the pass type ID, return existing ID if it already exists
          existing = self.find_by_identifier(identifier)
          return existing if existing

          pass_type_id = client.create_pass_type_id!(name, identifier)

          # Update self with the new device
          self.new(pass_type_id)
        end
      end
    end
  end
end
