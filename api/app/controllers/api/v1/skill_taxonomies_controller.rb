module Api
    module V1
        class SkillTaxonomiesController < ApiController
            authorize_auth_token! :assessor

            def index
                category = params[:category]
                cache_key = [
                    SkillTaxonomy.model_name,
                    category
                ]

                skill_taxonomies = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
                    skills = SkillTaxonomy.order(:skill_id)
                    skills = skills.where(category: category) if category.present?

                    skills.map do |skill|
                        ::Api::V1::SkillTaxonomySerializer.list(skill)
                    end
                end

                json_response(skill_taxonomies: skill_taxonomies)
            end

            def show
                skill = SkillTaxonomy.find_by!(skill_id: params[:skill_id])

                skill_detail = Rails.cache.fetch([SkillTaxonomy.model_name, skill], expires_in: 1.hour) do
                    ::Api::V1::SkillTaxonomySerializer.detail(skill)
                end

                json_response(skill: skill_detail)
            rescue ActiveRecord::RecordNotFound
                json_error("Skill not found", :not_found)
            end
        end
    end
end