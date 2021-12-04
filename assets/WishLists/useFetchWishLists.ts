import { useEffect, useState } from 'react';

export const useFetchWishLists = () => {
  const [wishLists, setWishLists] = useState<string>('');
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

        if (response.status >= 400 && response.status < 600) {
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

  return { wishLists: wishLists, error, loading };
};
