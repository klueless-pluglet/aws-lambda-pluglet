KManager.action :bootstrap do
  action do
    # application_name = :aws_lambda_pluglet
    application_name = 'aws-lambda-pluglet'

    # Ruby Gem Bootstrap
    director = KDirector::Dsls::RubyGemDsl
      .init(k_builder,
        on_exist:                   :skip,                      # %i[skip write compare]
        on_action:                  :queue                      # %i[queue execute]
      )
      .data(
        application:                application_name,
        application_description:    'A pluglet to create AWS Lambda functions and websites from a GPT prompt',
        author:                     'David Cruwys',
        author_email:               'david@ideasmen.com.au',
        initial_semver:             '0.0.1',
        main_story:                 'As a user, I want quickly create a AWS Lambda Function to host code, so quickly deploy functions',
        copyright_date:             Time.now.year,
        website:                    'http://appydave.com/klue/aws-lambda-pluglet'
      )
      .github(
        active: true,
        repo_name: application_name,
        organization: 'klueless-pluglet'
      ) do
        create_repository
        # delete_repository
        # list_repositories
        open_repository
      end
      .blueprint(
        active: true,
        name: :bin_hook,
        description: 'initialize repository',
        on_exist: :write) do

        run_command('git init')

        cd(:app)

        run_template_script('bin/runonce/git-setup.sh', dom: dom)

        add('.githooks/commit-msg').run_command('chmod +x .githooks/commit-msg')
        add('.githooks/pre-commit').run_command('chmod +x .githooks/pre-commit')

        add('.gitignore')

        run_command('git config core.hooksPath .githooks') # enable sharable githooks (developer needs to turn this on before editing rep)

        run_command("git add .; git commit -m 'chore: #{self.options.description.downcase}'; git push")
        run_command("gh repo edit -d \"#{dom[:application_description]}\"")

        add('README.md', dom: dom)
        add('CODE_OF_CONDUCT.md', dom: dom)
        add('LICENSE.txt', dom: dom)

        add('.github/workflows/main.yml')

        run_command("git add .; git commit -m 'chore: #{self.options.description.downcase}'; git push")
      end

    director.play_actions
  end
end

KManager.opts.app_name                    = 'aws-lambda-pluglet'
KManager.opts.sleep                       = 2
KManager.opts.reboot_on_kill              = 0
KManager.opts.reboot_sleep                = 4
KManager.opts.exception_style             = :short
KManager.opts.show.time_taken             = true
KManager.opts.show.finished               = true
KManager.opts.show.finished_message       = 'FINISHED :)'
