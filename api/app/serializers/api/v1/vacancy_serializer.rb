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

            def self.skill(skill, taxonomy)

                if skill.skill_id.present?
                    cache_key = [
                        VacancySkill.model_name.cache_key,
                        'find_by_skill_id',
                        VacancySkill.cache_version
                    ]

                    vacancy_skill = Rails.cache.fetch(cache_key, expires_in: 1.day) do
                        VacancySkill.find_by(skill_id: skill.skill_id)
                    end

                    {
                        id: skill.id,
                        skill_id: skill.skill_id,
                        skill_label: skill.skill_label,
                        expected_level: vacancy_skill.try(:expected_level),
                        scope_include: taxonomy.scope_include,
                        scope_exclude: taxonomy.scope_exclude,
                        l1_anchor: taxonomy.l1_anchor,
                        l2_anchor: taxonomy.l2_anchor,
                        l3_anchor: taxonomy.l3_anchor,
                        l4_anchor: taxonomy.l4_anchor,
                        l5_anchor: taxonomy.l5_anchor
                    }

                else
                    {
                        id: skill.id,
                        skill_id: skill.skill_id,
                        skill_label: skill.skill_label,
                        l1_anchor: skill.l1_anchor,
                        l2_anchor: skill.l2_anchor,
                        l3_anchor: skill.l3_anchor,
                        l4_anchor: skill.l4_anchor,
                        l5_anchor: skill.l5_anchor
                    }
                end



            end

            def self.detail_with_skills(model)
                skills = model.skills

                # Preload taxonomy anchors in one query to avoid N+1
                skill_ids = skills.filter_map(&:skill_id).uniq
                taxonomy_map = SkillTaxonomy.where(skill_id: skill_ids).index_by(&:skill_id)

                detail(model).merge(
                    skills: skills.map { |s| skill(s, taxonomy_map[s.skill_id]) }
                )
            end


        end
    end
end
