module Api
    module V1
        class AssessmentSerializer < BaseSerializer
            LIST_ATTRIBUTES = %i[id name time_limit_min].freeze

            DETAIL_ATTRIBUTES = LIST_ATTRIBUTES + %i[
                system_prompt
                latest_session
                created_by
                created_at
                updated_at
            ]

            def assessment_with_skills_json(assessment)
                assessment_json(assessment).merge(
                    skills: assessment.assessment_skills.order(:display_order).map do |s|
                        {
                            id: s.id,
                            skill_id: s.skill_id,
                            skill_label: s.skill_label,
                            is_custom: s.is_custom,
                            scope_include: s.scope_include,
                            scope_exclude: s.scope_exclude,
                            l1_anchor: s.l1_anchor,
                            l2_anchor: s.l2_anchor,
                            l3_anchor: s.l3_anchor,
                            l4_anchor: s.l4_anchor,
                            l5_anchor: s.l5_anchor,
                            expected_level: s.expected_level,
                            display_order: s.display_order
                        }
                    end
                )
            end


            def self.list(assessment)
                assessment.attributes.slice(*LIST_ATTRIBUTES.map(&:to_s))
            end

            def self.detail(assessment)
                latest = assessment.sessions.max_by(&:created_at)
                attributes = assessment.attributes.slice(*DETAIL_ATTRIBUTES.map(&:to_s))
                attributes.merge(
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