#-*- encoding: utf-8; tab-width: 2 -*-
require 'activeadmin'

module ActiveAdmin
  class ResourceDSL
    COLUMN_TYPES = %i[hstore jsonb json].freeze
    def hstore_editor(namespace: nil)
      before_save do |object,args|
        request_namespace = namespace || object.class.name.underscore.gsub('/', '_')

        if params.key? request_namespace
          object.class.columns_hash.select {|key,attr| COLUMN_TYPES.include?(attr.type)}.keys.each do |key|
            if params[request_namespace].key? key
              json_data = params[request_namespace][key]
              data = if json_data == 'null' or json_data.blank?
                       nil
                     else
                       JSON.parse(json_data)
                     end
              object.attributes = {key => data}
            end
          end
        else
          raise ActionController::ParameterMissing, "Hstore Editor either takes in a namespace keyword argument or infers the resouce class name from Model#class. The current classname #{request_namespace} is invalid"
        end
      end
    end
  end
end
