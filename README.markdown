# DotLocal, for versionable config files

DotLocal helps in managing config files. It's particularily suitable
for setups in which a master config files is under version control,
and specific environments override the default values with a _local_ copy of it.

DotLocal loads configuration from a settings file, then looks for
the presence of a _local_ version of it in the same folder.
If the _local_ copy is found, then keys of the two config files are merged
and keys contained in the _local_ copy takes precedence.

The resulting config hash is then verified to avoid the presence of
null of blank keys.

## Examples

Assuming you have a Rails app, but it can be whatever you want.

### Start a settings file

Assuming you have a settings.yml file in the current folder, put these lines
in an initalizer:

    Settings = DotLocal::Configuration.new
    Settings.load!

    Settings.this.is.my.key

### Rails.env as the root key

It's not mandatory, but you may want to have an env-scoped settings file
like this:

    development:
        site_name: Development Site!

    production:
        site_name: FooForBars

In this case just pass your current env during setup:

    Settings = DotLocal::Configuration.new(:env => Rails.env)

Now you can call:

    Settings.site_name


### Reload settings in development mode

Put this in your environments/development.rb file.

    config.to_prepare { Settings.reload! }

### Config options

Takes four options to the initialier:

* path : where to look for a settings.yml file. Default to the current directory.
* env : if to scope the settings file by env. Default is nil.
* file_name : what's the master file name to look for. Default is 'settings.yml'.
* local_file\_name : what suffix to use when looking for a local version.
    Default is 'local' that will look for settings.local.yml.

### Caveat

Always use strings - not symbols - for settings keys. Symbols are ignored.

## Why should I need this?

The most common way to deal with configuration files in a project is
to put a 'sample' version of the config file under version control.
That 'sample' version should act as a statement of all config keys the
app relies on. This approach works fine the majority of times, but
starts to become unhandy when dealing with large projects.

### Red, green, push, break code

Regardless of what you policy is, it may happen during development to
have a fully tested and green version of your app, and yet commit and
push broken code. This is easy to achieve when you have your app relying
on config keys which have to be copied manually to a sample settings file.

A team member may commit code that relies on a settings key that was
not copied on the sample settings file. Other team members may spend time
trying to figure out weird bugs due to the missing key. This is even worse when
your app normally starts witout checking for the presence of required
config variables.

### Lock your settings requirements

Most of the times, your app doesn't even know that a sample
config file is there. DotLocal workflow instead requires you
to have a settings file which acts as a statement.

You can keep sensible information away from the master file. Just keep
the keys there and leave them empty. The presence of a blank key will be
enough to raise an exception and force everybody to populate that
configuration in their local file.

## Note on Patches/Pull Requests

* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a future version unintentionally.
* Commit, do not mess with rakefile, version, or history. (if you want to have your own version, that is fine but bump version in a commit by itself in another branch so I can ignore when I pull)
* Send us a pull request. Bonus points for topic branches.

## License 

See LICENSE file.

