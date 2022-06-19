defmodule ExMachina.MongoTest do
  use ExUnit.Case

  @driver_opts [wtimeout: 100]

  defmodule MyRepo do
    use Mongo.Repo,
      topology: :mongo,
      otp_app: :ex_machina_mongo
  end

  defmodule Comment do
    use Mongo.Collection

    document do
      attribute(:author, String.t())
      attribute(:message, String.t())
    end
  end

  defmodule Post do
    use Mongo.Collection

    collection "posts" do
      attribute(:title, String.t())
      attribute(:visible, Boolean.t())
      embeds_many(:comments, Comment)
    end
  end

  setup do
    assert {:ok, pid} = start_supervised({Mongo, MyRepo.config()})
    Mongo.drop_database(pid, nil, w: 3)
    {:ok, [pid: pid]}
  end

  describe "When the :repo option is not provided" do
    defmodule NoRepoTestFactory do
      use ExMachina.Mongo

      def post_factory do
        %Post{
          title: "One editor to rule them all"
        }
      end
    end

    test "insert, insert_pair and insert_list raise helpful error messages if no repo was provided" do
      message = """
      insert/1, insert/2 and insert/3 are not available unless you provide the :repo option. Example:
      use ExMachina.Mongo, repo: MyApp.Repo
      """

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert(:post)
      end

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert_pair(:post)
      end

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert_list(4, :post)
      end

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert(:post, [], @driver_opts)
      end

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert_pair(:post, [], @driver_opts)
      end

      assert_raise RuntimeError, message, fn ->
        NoRepoTestFactory.insert_list(4, :post, [], @driver_opts)
      end
    end
  end

  describe "when provides a struct that is not a collection" do
    defmodule IsNotACollectionTestFactory do
      use ExMachina.Mongo, repo: MyRepo

      def user_factory do
        %{
          name: "username"
        }
      end
    end

    test "insert, insert_pair and insert_list raise helpful error messages if no repo was provided" do
      message = "%{name: \"username\"} is not a Mongo.Collection. Use `build` instead"

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert(:user)
      end

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert_pair(:user)
      end

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert_list(4, :user)
      end

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert(:user, [], @driver_opts)
      end

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert_pair(:user, [], @driver_opts)
      end

      assert_raise ArgumentError, message, fn ->
        IsNotACollectionTestFactory.insert_list(4, :user, [], @driver_opts)
      end
    end
  end

  describe "insert/2 insert_pair/2 insert_list/3" do
    defmodule TestFactory do
      use ExMachina.Mongo, repo: MyRepo

      def comment_factory do
        %Comment{
          author: sequence("anonymous"),
          message: sequence("message")
        }
      end

      def post_factory do
        %Post{
          title: "One editor to rule them all",
          visible: true,
          comments: []
        }
      end
    end

    test "insert, insert_pair and insert_list inserts records" do
      assert %Post{} = TestFactory.build(:post) |> TestFactory.insert()
      assert %Post{} = TestFactory.insert(:post, [], @driver_opts)
      assert %Post{} = TestFactory.insert(:post, visible: true)

      assert [%Post{}, %Post{}] = TestFactory.insert_pair(:post, [], @driver_opts)
      assert [%Post{}, %Post{}] = TestFactory.insert_pair(:post, visible: false)

      assert [%Post{}, %Post{}, %Post{}] = TestFactory.insert_list(3, :post, [], @driver_opts)
      assert [%Post{}, %Post{}, %Post{}] = TestFactory.insert_list(3, :post, visible: false)
    end

    test "insert_list/3 handles the number 0" do
      assert [] = TestFactory.insert_list(0, :post)
    end

    test "lazy records get evaluated with insert/2 and insert_* functions" do
      assert %Post{comments: [%Comment{}, %Comment{}]} =
               TestFactory.insert(:post, comments: fn -> TestFactory.build_pair(:comment) end)

      [%Post{comments: [comment1]}, %Post{comments: [comment2]}] =
        TestFactory.insert_pair(:post, comments: fn -> TestFactory.build_list(1, :comment) end)

      assert comment1 != comment2

      [post1, post2, post3] =
        TestFactory.insert_list(3, :post, comments: fn -> TestFactory.build_list(1, :comment) end)

      assert post1.comments != post2.comments
      assert post2.comments != post3.comments
      assert post3.comments != post1.comments
    end
  end
end
