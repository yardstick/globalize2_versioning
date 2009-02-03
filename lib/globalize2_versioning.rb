module Globalize
  module Model
    class Adapter
      def update_translations!
        @stash.each do |locale, attrs|
          next if attrs.empty?
          translation = nil
          if @record.versioned?
            translation = @record.globalize_translations.find_or_initialize_by_locale_and_current(locale.to_s, true)        
            translation.version ||= 1
            if @record.save_version?
              translation = translation.clone unless @record.new_record?        
              translation.version = highest_version + 1
            end
            translation.class.update_all( [ 'current = ?', false ], 
              { :current => true, :locale => locale.to_s, @record.class.name.underscore + '_id' => @record.id } ) 
            translation.current = true
          else
            translation = @record.globalize_translations.find_or_initialize_by_locale(locale.to_s)
          end
          attrs.each{|attr_name, value| translation[attr_name] = value }
          translation.save!
        end
        @stash.clear
      end

      def highest_version(locale = I18n.locale)
        # TODO do fallback thing
        @record.globalize_translations.maximum(:version, 
          :conditions => { :locale => locale.to_s, @record.class.name.underscore + '_id' => @record.id }) || 0
      end      
    end
    
    module ActiveRecord
      module Translated
        module Callbacks
          def globalize2_versioning
            if globalize_options[:versioned].blank?
              define_method :'versioned?', lambda { false }
            else
              include Versioned::InstanceMethods
            end
          end
        end
        module Extensions
          def by_locales(locales)
            if proxy_owner.versioned?
              find :all, :conditions => { :locale => locales.map(&:to_s), :current => true }
            else
              find :all, :conditions => { :locale => locales.map(&:to_s) }
            end
          end          
        end
      end
      
      module Versioned
        module InstanceMethods
          def versioned?; true end
          
          def version(locale = I18n.locale)
            translation = globalize_translations.find_by_locale_and_current(locale.to_s, true)
            translation ? translation.version : nil
          end
          
          def revert_to(version, locale = I18n.locale)
            new_translation = globalize_translations.find_by_locale_and_version(locale.to_s, version)
            return false unless new_translation
            translation = globalize_translations.find_by_locale_and_current(locale.to_s, true)
            transaction do
              translation.update_attribute :current, false
              new_translation.update_attribute :current, true
            end
            
            # clear out cache
            globalize.clear
            true
          end
                                       
          # Checks whether a new version should be saved or not.
          def save_version?
            new_record? || ( globalize_options[:versioned].map {|k| k.to_s } & changed ).length > 0
          end                
        end        
      end
    end
  end
end