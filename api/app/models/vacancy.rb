# frozen_string_literal: true

class Vacancy < ApplicationRecord
    include TenantScoped

    has_one :assessment
    has_many :vacancy_skills, dependent: :destroy
    has_many :fit_gap_reports, dependent: :destroy

    validates :role_title, presence: true

    alias_attribute :skills, :vacancy_skills

    accepts_nested_attributes_for :vacancy_skills, allow_destroy: true, reject_if: :all_blank


    STATUS = Data.define(:draft, :running, :completed).new(
        'draft',
        'running',
        'completed'
    )

    CACHE_VERSION_KEY = 'vacancies:index:version'

    before_create :set_default_values

    def self.cache_version
        Rails.cache.fetch(CACHE_VERSION_KEY) { SecureRandom.uuid }
    end

    def self.invalidate_cache
        Rails.cache.write(CACHE_VERSION_KEY, SecureRandom.uuid)
        Rails.cache.delete([cache_key, id])
    end


    private

    def set_default_values
        self.status ||= STATUS.draft
    end

end
