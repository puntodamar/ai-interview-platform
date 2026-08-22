module Api
    module V1
        class VacancySerializer
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

            def self.detail_with_skills(vacancy)
                skills = vacancy.vacancy_skills

                # Preload taxonomy anchors in one query to avoid N+1
                skill_ids = skills.filter_map(&:skill_id).uniq
                taxonomy_map = SkillTaxonomy.where(skill_id: skill_ids).index_by(&:skill_id)

                detail(vacancy).merge(
                    skills: skills.map { |s| skill(s, taxonomy_map[s.skill_id]) }
                )
            end

            def self.skill(skill, taxonomy)
                {
                    id: skill.id,
                    skill_id: skill.skill_id,
                    skill_label: skill.skill_label,
                    expected_level: skill.expected_level,
                    l1_anchor: taxonomy&.l1_anchor,
                    l2_anchor: taxonomy&.l2_anchor,
                    l3_anchor: taxonomy&.l3_anchor,
                    l4_anchor: taxonomy&.l4_anchor,
                    l5_anchor: taxonomy&.l5_anchor
                }
            end


            def self.pagination_meta(collection)
                {
                    current_page: collection.current_page,
                    total_pages: collection.total_pages,
                    total_count: collection.total_count,
                    per_page: collection.limit_value
                }
            end
        end
    end
end
