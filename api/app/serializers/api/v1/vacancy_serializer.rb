module Api
    module V1
        class VacancySerializer < BaseSerializer
            LIST_ATTRIBUTES = %i[id role_title status].freeze

            DETAIL_ATTRIBUTES = LIST_ATTRIBUTES + %i[
                culture_dimensions
                competency_expectations
                created_by
                created_at
                updated_at
            ].freeze

            def self.list(vacancy)
                vacancy.attributes.slice(*LIST_ATTRIBUTES.map(&:to_s))
            end

            def self.detail(vacancy)
                vacancy.attributes.slice(*DETAIL_ATTRIBUTES.map(&:to_s))
            end
        end
    end
end
