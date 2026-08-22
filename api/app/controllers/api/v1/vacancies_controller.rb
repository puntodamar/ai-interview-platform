# frozen_string_literal: true

module Api
    module V1
        class VacanciesController < ApiController
            authorize_auth_token! :assessor

            before_action :set_vacancy, only: %i[show update destroy]

            # GET /api/v1/vacancies
            def index
                vacancies = paginate(Vacancy.order(created_at: :desc))

                json_response(
                    vacancies: vacancies.map { |skill| ::Api::V1::VacancySerializer.list(skill) },
                    meta: ::Api::V1::VacancySerializer.pagination_meta(vacancies)
                )
            end

            # GET /api/v1/vacancies/:id
            def show
                json_response(vacancy: ::Api::V1::VacancySerializer.detail_with_skills(@vacancy))
            end

            # POST /api/v1/vacancies
            def create
                vacancy = Vacancy.new(vacancy_params)
                vacancy.created_by = current_user.id

                if vacancy.save
                    if ENV['APP_DEBUG'].eql?('true')
                        json_response({ vacancy: ::Api::V1::VacancySerializer.detail_with_skills(vacancy) }, :created)
                    else
                        json_response({ success: true })
                    end

                else
                    json_error(vacancy.errors.full_messages.first, :unprocessable_entity)
                end
            end

            # PUT /api/v1/vacancies/:id
            def update
                if @vacancy.update(vacancy_params)
                    json_response(vacancy: ::Api::V1::VacancySerializer.detail_with_skills(@vacancy))
                else
                    json_error(@vacancy.errors.full_messages.first, :unprocessable_entity)
                end
            end

            # DELETE /api/v1/vacancies/:id
            def destroy
                @vacancy.destroy
                json_response(message: 'Vacancy deleted')
            end

            private

            def set_vacancy
                @vacancy = Vacancy.find(params[:id])
            rescue ActiveRecord::RecordNotFound
                json_error('Vacancy not found', :not_found)
            end

            def vacancy_params
                params.require(:vacancy).permit(
                    :role_title,
                    :status,
                    :culture_dimensions,
                    :competency_expectations,
                    vacancy_skills_attributes: %i[
                        id skill_id skill_label expected_level _destroy
                    ]
                )
            end
        end
    end
end
