# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ShipchoiceDb.Repo.insert!(%ShipchoiceDb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias ShipchoiceDb.User

User.insert(%{
  name: "Admin",
  username: "admin",
  password: "password",
  is_admin: true,
})

User.insert(%{
  name: "User",
  username: "user",
  password: "password",
  is_admin: false,
})
