module Api
    module V1
        class SkillTaxonomiesController < ApiController
            authorize_auth_token! :assessor

            def index
                skills = SkillTaxonomy.order(:skill_id)
                skills = skills.where(category: params[:category]) if params[:category].present?

                json_response(
                    skill_taxonomies: skills.map {|skill| ::Api::V1::SkillTaxonomySerializer.list(skill)}
                )
            end

            def show
                skill = SkillTaxonomy.find_by!(skill_id: params[:skill_id])

                json_response(
                    skill: ::Api::V1::SkillTaxonomySerializer.detail(skill)
                )
            rescue ActiveRecord::RecordNotFound
                json_error('Skill not found', :not_found)
            end
        end
    end
end