# frozen_string_literal: true

module Api
    module V1
        class VacanciesController < ApiController
            authorize_auth_token! :assessor

            before_action :set_vacancy, only: %i[show update destroy]

            # GET /api/v1/vacancies
            def index
                cache_key = [
                    Vacancy.model_name,
                    'index',
                    params[:status],
                    params[:q],
                    params[:page],
                    params[:per_page]
                ]

                result = Rails.cache.fetch(cache_key, expires_in: 1.hour) do
                    vacancies = Vacancy.order(
                        Arel.sql(
                            "CASE status WHEN 'running' THEN 1 WHEN 'draft' THEN 2 WHEN 'completed' THEN 3 END"
                        ),
                        created_at: :desc
                    )

                    vacancies = vacancies.where(status: params[:status]) if params[:status].present?

                    if params[:q].present?
                        q = "%#{params[:q]}%"

                        vacancies = vacancies.where(
                            'role_title ILIKE :q
                             OR culture_dimensions ILIKE :q
                             OR competency_expectations ILIKE :q',
                            q: q
                        )
                    end

                    vacancies = paginate(vacancies)

                    {
                        vacancies: vacancies.map do |vacancy|
                            ::Api::V1::VacancySerializer.list(vacancy)
                        end,
                        meta: ::Api::V1::VacancySerializer.pagination_meta(vacancies)
                    }
                end

                json_response(result)
            end

            # GET /api/v1/vacancies/:id
            def show
                vacancy = Rails.cache.fetch([Vacancy.model_name, @vacancy.id], expires_in: 1.hour) do
                    ::Api::V1::VacancySerializer.detail_with_skills(@vacancy)
                end

                json_response(vacancy: vacancy)
            end

            # POST /api/v1/vacancies
            def create
                vacancy = Vacancy.new(vacancy_params)
                vacancy.created_by = current_user.id

                if vacancy.save
                    if ENV['APP_DEBUG'].eql?('true')
                        json_response(
                            {
                                vacancy: ::Api::V1::VacancySerializer.detail_with_skills(vacancy)
                            },
                            :created
                        )
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
                    Rails.cache.delete([Vacancy.model_name, @vacancy.id])

                    json_response(
                        vacancy: ::Api::V1::VacancySerializer.detail_with_skills(@vacancy)
                    )
                else
                    json_error(@vacancy.errors.full_messages.first, :unprocessable_entity)
                end
            end

            # DELETE /api/v1/vacancies/:id
            def destroy
                vacancy_id = @vacancy.id
                @vacancy.destroy
                Rails.cache.delete([Vacancy.model_name, vacancy_id])
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