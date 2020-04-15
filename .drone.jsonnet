local repoName = "redditopenttd/openttd";

local GameBuild(name, channel, tags) = {
  kind: "pipeline",
  name: name,
  when: [
      {
        branch: [
            "master"
        ],
        event: [
            "cron",
            "push"
        ],
        target: [
            {
                include: [
                    "weekly"
                ],
            },
        ],
      }
  ],
  volumes: [
    {
      name: "cache",
      temp: {},
    },
  ],
  steps: [
    {
      name: "determine-build-version",
      image: "redditopenttd/cdn_version_scraper",
      settings: {
        CHANNEL: channel,
        OUTPUT_FILE: "/version_store/env"
      },
      volumes: [
        {
          name: "cache",
          path: "/version_store"
        },
      ],
    },
    {
      name: "build",
      image: "plugins/docker",
      settings: {
        username: {
          from_secret: "docker_username"
        },
        password: {
          from_secret: "docker_password"
        },
        repo: repoName,
      },
      commands: [
        "source /version_store/env",
        "export PLUGIN_BUILD_ARGS=\"OPENTTD_VERSION=$OPENTTD_VERSION\"",
        "echo -n \"" + std.join(",", tags) + ",$OPENTTD_VERSION\" > .tags",
        "/usr/local/bin/dockerd-entrypoint.sh /bin/drone-docker",
      ],
      volumes: [
        {
          name: "cache",
          path: "/version_store"
        },
      ],
    }
  ]
};

[
  GameBuild("build-stable", "stable", ["latest", "stable"]),
  GameBuild("build-testing", "testing", ["testing", "rc", "beta"])
  # Nightlies are currently disabled pending fixes to the build flow
  # GameBuild("build-nightly", "master", ["nightly"]),
]