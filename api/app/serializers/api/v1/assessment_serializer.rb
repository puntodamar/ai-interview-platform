module Api
    module V1
        class AssessmentSerializer < BaseSerializer
            LIST_ATTRIBUTES = %i[id time_limit_min].freeze

            DETAIL_ATTRIBUTES = LIST_ATTRIBUTES + %i[
                vacancy_id
                system_prompt
                latest_session
                created_by
                created_at
                updated_at
            ]

            def self.list(assessment)
                assessment.attributes
                          .slice(*LIST_ATTRIBUTES.map(&:to_s))
                          .merge(
                              name: assessment.vacancy&.role_title
                          )
            end

            def self.detail_with_skills(assessment)
                skills = assessment.skills.order(:display_order)

                skill_ids = skills.filter_map(&:skill_id).uniq
                taxonomy_map = SkillTaxonomy
                                   .where(skill_id: skill_ids)
                                   .index_by(&:skill_id)

                detail(assessment).merge(
                    skills: skills.map do |s|
                        merge = {
                            is_custom: s.is_custom,
                            scope_include: s.scope_include,
                            scope_exclude: s.scope_exclude,
                            display_order: s.display_order
                        }

                        skill(s, taxonomy_map[s.skill_id]).merge(merge)
                    end
                )
            end

            def self.detail(assessment)
                latest = assessment.sessions.max_by(&:created_at)

                assessment.attributes
                          .slice(*DETAIL_ATTRIBUTES.map(&:to_s))
                          .merge(
                              name: assessment.vacancy&.role_title,
                              latest_session: latest && {
                                  id: latest.id,
                                  status: latest.status,
                                  end_reason: latest.end_reason
                              }
                          )
            end
        end
    end
end