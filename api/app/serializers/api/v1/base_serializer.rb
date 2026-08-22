module Api
    module V1
        class BaseSerializer
            def self.pagination_meta(collection)
                {
                    current_page: collection.current_page,
                    total_pages: collection.total_pages,
                    total_count: collection.total_count,
                    per_page: collection.limit_value
                }
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
        end
    end
end