import WishLists from './WishLists';
import { useEffect, useState } from 'react';

export const WishListsPage = () => {
  const [wishLists, setWishLists] = useState<{ message: string }>({ message: '' });
  const [error, setError] = useState<Error | null>(null);
  const [loading, setLoading] = useState<boolean>(false);

  useEffect(() => {
    const fetchWishLists = async () => {
      try {
        setLoading(true);

        const headers = new Headers();
        headers.append('Accept', 'application/json');

        const response = await fetch('/api/wishlists', {
          headers: headers,
          method: 'GET',
          mode: 'cors',
        });

        if (response.status >= 400) {
          setError(new Error(`Bad response from the server (status ${response.status})!`));
        }

        const wishLists = await response.json();

        setLoading(false);

        setWishLists(wishLists);
      } catch (error) {
        error instanceof Error ? setError(error) : setError(new Error('Something went terribly wrong…'));
      }
    };

    fetchWishLists();
  }, []);

  if (loading) {
    return <div>Loading…</div>;
  }

  if (error) {
    return <div>{error.message}</div>;
  }

  return <WishLists wishLists={wishLists} />;
};
