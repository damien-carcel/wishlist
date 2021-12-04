import { useFetchWishLists } from './useFetchWishLists';
import WishLists from './WishLists';

export const WishListsPage = () => {
  const { wishLists, error, loading } = useFetchWishLists();

  if (loading) {
    return <div>Loading…</div>;
  }

  if (error) {
    return <div>Loading…</div>;
  }

  return <WishLists wishLists={wishLists} />;
};
